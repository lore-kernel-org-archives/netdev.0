From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: net-2.6.24 GIT state
Date: Thu, 9 Aug 2007 17:40:07 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708091721030.24369@kivilampi-30.cs.helsinki.fi>
References: <20070809.022823.31781972.davem@davemloft.net>
 <Pine.LNX.4.64.0708091233050.24369@kivilampi-30.cs.helsinki.fi>
 <20070809.041034.93473045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-52993985-1186669972=:24369"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45668 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S938450AbXHIOkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 10:40:09 -0400
In-Reply-To: <20070809.041034.93473045.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0708091734580.24369@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-52993985-1186669972=:24369
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0708091734581.24369@kivilampi-30.cs.helsinki.fi>

On Thu, 9 Aug 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 9 Aug 2007 12:50:51 +0300 (EEST)
> 
> Ok, in order to get this started I merged the above patches
> into net-2.6.24
> 
> I'm exhausted and done for today. :-)

:-)

> We can work on the other bits next. 

Next step:

http://www.cs.helsinki.fi/u/ijjarvin/tcp-rebase/after-reorder/

...I put some effort to reorganization and there's the result, please 
_don't_ take the new SACK block-validator yet as I haven't yet put it 
under any testing (it's the only difference this reordering of patches 
seems to have introduced :-)). The first five commits touch left_out (4 
latest fix bug and "flaws" I made in the first commit), I could combine 
them into a single one if you want to.

...Notice that part of the next step includes work that hasn't yet been 
posted to netdev at all (was from my not yet submitted wip portion of 
it). Would you prefer me to post them using the usual procedure?

> > ...Taking IsReno/IsFack removal is probably going to be hardest one, as it 
> > will conflict a lot. ...Maybe some sed work in patches would reduce # of 
> > conflicts instead of trying cherry-pick+rebase.
> 
> Yes, such patch hand editing techniques can help in these cases.

...it helped a lot in the process :-).


-- 
 i.
---696243703-52993985-1186669972=:24369--
