From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 3/3] x_tables: Factor out 16bit aligment
 ifname_compare()
Date: Sun, 11 Jan 2015 23:23:01 +0100 (CET)
Message-ID: <alpine.LSU.2.11.1501112257580.10101@nerf60.vanv.qr>
References: <1421009571-5279-1-git-send-email-richard@nod.at>  <1421009571-5279-4-git-send-email-richard@nod.at>  <1421009969.9233.5.camel@perches.com> <54B2E4DD.90200@nod.at> <1421010853.9233.7.camel@perches.com> <54B2EB81.5050604@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54B2EB81.5050604@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sunday 2015-01-11 22:30, Richard Weinberger wrote:
>>>> Perhaps this would be better as bool ifname_compare
>
>Anyway, I agree with Linus wrt. bool.
>https://lkml.org/lkml/2013/8/31/138

Had the function return "bool", it would have been obvious enough
what to do with its return type. A return type of "int" might have
hinted towards negative-is-error (in general) or strcmpish values
(functions doing string compare work).

Now that it returns "unsigned long", one is pressed to look at the=20
function body (not bad per se, but it is a hump) for the return=20
value's semantics.

Linus says bool is dangerous to the unsuspecting user=C2=A0=E2=80=94 bu=
t so is
"volatile", microwave ovens, etc. If the kernel really cared for
entry-level coders, it would be written in something like MISRA C.
