From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] 8 bytes kernel memory disclosure in AppleTalk getsockname.
Date: Wed, 26 Aug 2009 21:01:56 +0900
Message-ID: <200908262101.DBJ57868.OHOFFVLQOtMFSJ@I-love.SAKURA.ne.jp>
References: <20090826111247.GA79673@clem1.netasq.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: clement.lecigne@netasq.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932865AbZHZMZk@vger.kernel.org>
In-Reply-To: <20090826111247.GA79673@clem1.netasq.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clement LECIGNE wrote:
> Here is a patch that zero the whole sockaddr_at structure before
> processing it. It should fix this bug.

Same kind of bug at http://lkml.org/lkml/2006/7/25/51 .
I wonder why not zero'ing sockaddr at the caller rather than
zero'ing at individual ->getname(). Doing so will save some lines.
