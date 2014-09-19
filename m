From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 00/29] Add support for the Intel FM10000 Ethernet
 Switch Host Interface
Date: Fri, 19 Sep 2014 09:58:04 -0700
Message-ID: <CAADnVQKuzQ82HgMXaKcjxZXwGXB6FchhC536u=KfnBLP3+U-Gw@mail.gmail.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
	<541C0C01.6080708@mojatatu.com>
	<541C43AE.3030402@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, nhorman@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>,
	matthew.vick@intel.com, jeffrey.t.kirsher@intel.com,
	sassmann@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:34411 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756107AbaISQ6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 12:58:05 -0400
Received: by mail-qa0-f51.google.com with SMTP id i13so2876328qae.24
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 09:58:04 -0700 (PDT)
In-Reply-To: <541C43AE.3030402@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 7:54 AM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
>
> Since the switch can support up to 9 of these we are treating the host
> interface driver as though it is a NIC driver.  We need to usually ship

Am I reading it right that 9 hosts can be attached to this one physical device
and they see it as different 'physical' nics ?
