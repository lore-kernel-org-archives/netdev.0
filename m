From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 14749] New: Kernel locks up after a few minutes
 of heavy surfing
Date: Tue, 08 Dec 2009 15:39:35 +0100
Message-ID: <4B1E6527.4020605@gmail.com>
References: <20091208120021.GA24223@hmsreliant.think-freely.org> <219482.3038.qm@web52901.mail.re2.yahoo.com> <20091208134157.GB24223@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Rankin <rankincj@yahoo.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, stable@kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57009 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755642AbZLHOkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 09:40:21 -0500
In-Reply-To: <20091208134157.GB24223@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> On Tue, Dec 08, 2009 at 05:39:28AM -0800, Chris Rankin wrote:
>> --- On Tue, 8/12/09, Neil Horman <nhorman@tuxdriver.com> wrote:
>>> 30 minutes isn't too long to wait for an error to appear, I think.
>> Except it's a very "busy" waiting process with me actively surfing t=
he web. I can't automate that. I'm still not entirely sure what the tri=
gger condition is.
>>
> Sure you can, generate a list of sites that you visited and access th=
em all with
> a curl or wget script.  I would imagine thats a reasonable test to tr=
igger the
> reproducer.

Yes, but I suspect a multi threading bug, or vm , or X11, or something.

Andi posted a futex patch that is worth to try, if machine is swaping a=
 bit.

Chris, please provide as much information as you can

# cat /proc/cpuinfo
# cat /proc/meminfo
# ps aux
# scripts/ver_linux
