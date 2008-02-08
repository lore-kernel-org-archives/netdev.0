From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] ipvs: Make the synchronization interval controllable
Date: 08 Feb 2008 15:23:47 +0100
Message-ID: <871w7n34ss.fsf@basil.nowhere.org>
References: <1202333990-19359-1-git-send-email-sven.wegener@stealer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sven Wegener <sven.wegener@stealer.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759920AbYBHOYM@vger.kernel.org>
In-Reply-To: <1202333990-19359-1-git-send-email-sven.wegener@stealer.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sven Wegener <sven.wegener@stealer.net> writes:

> The default synchronization interval of 1000 milliseconds is too high for a
> heavily loaded director. Collecting the connection information from one second
> and then sending it out in a burst will overflow the socket buffer and lead to
> synchronization information being dropped. Make the interval controllable by a
> sysctl variable so that users can tune it.

It would be better if the defaults just worked under all circumstances.
So why not just lower the default?

Or the code could detect overflowing socket buffers and lower the 
value dynamically.

-Andi
