From: Ofer Heifetz <oferh@marvell.com>
Subject: RE: Splice status
Date: Mon, 5 Jul 2010 13:52:06 +0300
Message-ID: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
 <AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from galiil.marvell.com ([199.203.130.254]:63081 "EHLO
	galiil.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab0GEKxT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 06:53:19 -0400
In-Reply-To: <AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am using Samba, so from my understanding of the source code, it loops and performs splice(sock, pipe) and splice(pipe, fd). There is no flush of any sort in between.

When you say drain you mean to flush all data to pipe?

-Ofer

-----Original Message-----
From: Changli Gao [mailto:xiaosuo@gmail.com] 
Sent: Monday, July 05, 2010 12:59 PM
To: Ofer Heifetz
Cc: netdev@vger.kernel.org
Subject: Re: Splice status

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
