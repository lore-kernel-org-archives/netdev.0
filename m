From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net 1/4] net/mlx4_core: Adjust port number in qp_attach
 wrapper when detaching
Date: Fri, 2 May 2014 13:43:34 +0300
Message-ID: <CAJZOPZKd+SePdyxxN=W2M9uLf2_RJWLii9bn-JKvC+F5VzKBJw@mail.gmail.com>
References: <1398948716-6765-1-git-send-email-ogerlitz@mellanox.com>
	<1398948716-6765-2-git-send-email-ogerlitz@mellanox.com>
	<5362A682.60101@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roland Dreier <roland@kernel.org>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:48114 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbaEBKne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 06:43:34 -0400
Received: by mail-qc0-f173.google.com with SMTP id r5so4546377qcx.18
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 03:43:34 -0700 (PDT)
In-Reply-To: <5362A682.60101@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 1, 2014 at 10:54 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 05/01/2014 04:51 PM, Or Gerlitz wrote:

>> +static int mlx4_adjust_port(struct mlx4_dev *dev, int slave,
>> +                           u8 *gid, enum mlx4_protocol prot)
>> +{
>> +       int real_port;
>> +
>> +       if (prot != MLX4_PROT_ETH)
>> +               return 0;
>> +
>> +       if (dev->caps.steering_mode == MLX4_STEERING_MODE_B0 ||
>> +           (dev->caps.steering_mode == MLX4_STEERING_MODE_DEVICE_MANAGED)) {
>
>
>    It looks a bit strange when you enclose in parens the second == but not the first. In fact, they're not at all necessary.

Well... so we'll fix it and resubmit
