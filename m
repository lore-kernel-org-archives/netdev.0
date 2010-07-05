From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Splice status
Date: Mon, 5 Jul 2010 17:59:19 +0800
Message-ID: <AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ofer Heifetz <oferh@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:39088 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754596Ab0GEJ7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 05:59:40 -0400
Received: by vws5 with SMTP id 5so5849534vws.19
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 02:59:39 -0700 (PDT)
In-Reply-To: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 5, 2010 at 5:26 PM, Ofer Heifetz <oferh@marvell.com> wrote:
> Hi
>
> I have been trying to test splice on kernel 2.6.35_4 (x86) from Samba (v3.4.7) but could not copy more than ~60MB to the Samba server share.
>
> Strace shows that the splice got stuck in blocking mode on the splice call from socket to pipe.
>

Did you drain the pipe before calling splice(2) to move data from
socket to pipe?

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
