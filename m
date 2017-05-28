From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Sun, 28 May 2017 15:33:21 +0300
Message-ID: <CAJ3xEMhpzVO8UaHLd3MAussvOzOs28KbbKr-nBaYDx18z6WGPA@mail.gmail.com>
References: <20170523114404.20387-1-saeedm@mellanox.com> <20170523114404.20387-5-saeedm@mellanox.com>
 <20170524165059.42lmrwzzcxvi2sf7@ast-mbp> <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170526030701.du4345mbprhcwjyi@ast-mbp> <CALzJLG98D=3yMJV_q4sjVNG41AERFRU+6rwqQJsxnRuVeDTPdA@mail.gmail.com>
 <20170526175624.5xxflpf24je5673h@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Ilan Tayari <ilant@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jsorensen@fb.com" <jsorensen@fb.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>,
        linux-fpga@vger.kernel.org,
        Alan Tull <atull@opensource.altera.com>, yi1.li@linux.intel.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35473 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750830AbdE1MdW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 May 2017 08:33:22 -0400
In-Reply-To: <20170526175624.5xxflpf24je5673h@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 26, 2017 at 8:56 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, May 26, 2017 at 11:59:26AM +0300, Saeed Mahameed wrote:

>> But i agree with you some serious API brainstorming should be
>> considered, but not at this stage, this patch only tells the ConnectX card
>> (if you have FPGA, please enable it).

> serious api discussion needs be done before things like eswitch, fpga
> exposed to users otherwise we end up in the eswitch situation that
> drops packets based on its own invisible logic, but with hidden fpga
> it will be even more obscure.


Alexei,

ACK for your comment on e-switch, what we call the legacy mode for SRIOV in
Linux was a big mistake.

As you know, since 4.8 we're @ MLNX are working to fix it... we introduced a
model for VF port representors which has set the foundations for
e-switch data-path
to be programmed as an offload for kernel SW switching. We also
introduced the code
to offload TC flower base data-path and support that in for both
switch (Spectrum) ASIC
(mlxsw driver) and NIC ASIC (mlx5 driver)

Or.
