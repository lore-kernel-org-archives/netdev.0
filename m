From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Wed, 3 Sep 2008 15:05:07 +0200
Message-ID: <7e0dd21a0809030605odc28306re8b7640f0632ac36@mail.gmail.com>
References: <20080902194603.GA2825@2ka.mipt.ru>
	 <7e0dd21a0809030056q2bfd0344kf3b86a90a4b3fc5f@mail.gmail.com>
	 <7e0dd21a0809030338k3335a5eah4be6e27c26aecf59@mail.gmail.com>
	 <20080903.040626.198546183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:60252 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbYICNFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 09:05:08 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2758698rvb.1
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2008 06:05:07 -0700 (PDT)
In-Reply-To: <20080903.040626.198546183.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for misunderstanding,

TCP socket, transferring 20Mbytes file (located in initramfs) in loop
with sendfile() : 5.7Mbytes/s

Best regards,
Johann

On Wed, Sep 3, 2008 at 1:06 PM, David Miller <davem@davemloft.net> wrote:
> From: "Johann Baudy" <johaahn@gmail.com>
> Date: Wed, 3 Sep 2008 12:38:53 +0200
>
>> I'm not able to exceed 15Mo/s even with vmsplice/splice duo.
>
> I think you misunderstood what Evgeniy was asking of you.
>
> He was asking how fast you can transfer data over this
> interface using a normal TCP socket to a remove host,
> via sendfile() or splice().
>



-- 
Johann Baudy
johaahn@gmail.com
