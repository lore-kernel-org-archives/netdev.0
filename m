From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Re : Oops preceded by WARNING: at net/ipv4/tcp_input.c:1571
 tcp_remove_reno_sacks()
Date: Thu, 15 Nov 2007 13:51:59 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711151320280.29353@kivilampi-30.cs.helsinki.fi>
References: <902344.71635.qm@web26211.mail.ukl.yahoo.com>
 <Pine.LNX.4.64.0711111216170.12719@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0711132321340.3997@kivilampi-30.cs.helsinki.fi>
 <20071113.210431.141662500.davem@davemloft.net> <20071115113120.7276ad52@cheypa.inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Guillaume Chazarain <guichaz@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57528 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755867AbXKOLwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 06:52:01 -0500
In-Reply-To: <20071115113120.7276ad52@cheypa.inria.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Nov 2007, Guillaume Chazarain wrote:

> David Miller <davem@davemloft.net> wrote:
> 
> > Chazarain please let us know if it does indeed cure your
> > problem.
> 
> Unfortunately, I couldn't manage to reproduce the problem with an
> unpatched kernel. But your investigation Ilpo was really impressive.

These are usually very sensitive on other traffic because even a simple 
change in packet pattern changes behavior enough for it do disappear.
The same thing occurred with the month ago fackets_out miscount as 
well, at different weekday it just wasn't reproducable. ...Anyway, I'm 
pretty sure it's now fixed because there's a simple explination to it 
due to the frto_highmark premature clearing bug. But if you would still 
end up seeing them after that, make sure to report it... :-)

> BTW, even though I messed up the yahoo webmail configuration, you can
> call me by my first name: Guillaume ;-)

Fair enough. :-)

> Thanks again for such an awesome bug fixing attitude!

The best thing is that usually when forced to really think what could go 
wrong, also other, unrelated bugs seem to come up, though up to 10%
of the initial oh-nos end up being genuine bugs. ...Thus I still have 
couple of miscount-due-to-GSO&hints fixes to do as a result of this 
venture besides the problems already fixed.

-- 
 i.
