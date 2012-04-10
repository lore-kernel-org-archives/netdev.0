From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: a F-RTO question
Date: Tue, 10 Apr 2012 11:34:08 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1204101128550.2966@wel-95.cs.helsinki.fi>
References: <4F7281ED.1060603@gmail.com> <CAJkE24+qgK4_cGtiEi6hWDFS2EVYPajHY3pigwh_RqguwsedNg@mail.gmail.com> <4F728EC9.1050302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Chao Pei <peichao85@gmail.com>, Netdev <netdev@vger.kernel.org>
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40762 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253Ab2DJIjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 04:39:10 -0400
In-Reply-To: <4F728EC9.1050302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Mar 2012, Li Yu wrote:

> Even, the reason is latter, it also means the netowrk already is
> recovered from temporarily congestion or disordered state, so we also should
> not enter loss state.

There are also other considerations in this btw, some devices are simply 
broken and go to RTO loop increasing the RTOs exponentially if we wouldn't 
force retransmit of the next segment (one of those newly sent segments) 
that isn't strictly mandatory imho. ...We used to do something more 
clever here and avoided that retransmission but learned the hard way that 
there's simply no way around it.

-- 
 i.
