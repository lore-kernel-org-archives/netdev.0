From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [TCP]: Fix logic breakage due to DSACK separation
Date: Sat, 16 Jun 2007 10:34:08 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0706161004570.13362@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0706151606220.15358@kivilampi-30.cs.helsinki.fi>
 <20070615.151439.70217492.davem@davemloft.net>
 <Pine.LNX.4.64.0706160121180.12770@kivilampi-30.cs.helsinki.fi>
 <20070615.163128.32622610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-379229709-1181978861=:13362"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35987 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbXFPHeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jun 2007 03:34:10 -0400
In-Reply-To: <20070615.163128.32622610.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0706161028500.13362@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-379229709-1181978861=:13362
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0706161028501.13362@kivilampi-30.cs.helsinki.fi>

On Fri, 15 Jun 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Sat, 16 Jun 2007 02:04:25 +0300 (EEST)
> 
> > On Fri, 15 Jun 2007, David Miller wrote:
> > 
> > > Patch applied.
> > 
> > ...I think it should go to stable as well.
> 
> I thought Baruch's DSACK seperation that created this problem didn't
> go in until 2.6.22?

Then my gitk lies... :-) It claims for the particular commit:
	Follows: v2.6.20
	Preceeds: v2.6.21-rc1

$ git-describe 6f74651ae626ec672028587bc700538076dfbefb
v2.6.20-835-g6f74651

...It's definately in 2.6.21 already.

-- 
 i.
---696243703-379229709-1181978861=:13362--
