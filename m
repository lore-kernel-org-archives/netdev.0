From: Paul Moore <paul.moore@hp.com>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Mon, 7 Apr 2008 11:40:59 -0400
Message-ID: <200804071140.59247.paul.moore@hp.com>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp> <20080404122408.986477936@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	Toshiharu Harada <haradats@nttdata.co.jp>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:20824 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbYDGPlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 11:41:03 -0400
In-Reply-To: <20080404122408.986477936@I-love.SAKURA.ne.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 April 2008 8:23:12 am Tetsuo Handa wrote:
> This file contains modifications against kernel source code
> needed to use TOMOYO Linux 1.6.
>
> Although LSM hooks are provided for performing access control,
> TOMOYO Linux 1.6 doesn't use LSM because of the following reasons.

Hello,

I understand your frustration with the existing LSM hooks/API and your 
reasoning for abandoning LSM in favor of a new set of hooks, however, I 
think this sets a dangerous precedence which could result in an 
abundance of security related hooks scattered throughout the kernel.  I 
would much rather see the LSM API extended/tweaked to support the needs 
of SAKURA and TOMOYO than ignored and duplicated; I suspect several 
others will say the same.

You have made good progress with TOMOYO so far and if I can remember 
correctly you really only have one hurdle left, the VFS portion.  
Please continue to seek a solution to this that fits within the LSM 
framework.

Thank you.

-- 
paul moore
linux @ hp
