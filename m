From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Network privilege separation.
Date: Wed, 07 Jan 2009 22:10:45 +0100
Message-ID: <87mye2yg8a.fsf@basil.nowhere.org>
References: <1231307334-9542-1-git-send-email-michael@laptop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Stone <michael@laptop.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761438AbZAGVKx@vger.kernel.org>
In-Reply-To: <1231307334-9542-1-git-send-email-michael@laptop.org> (Michael Stone's message of "Wed,  7 Jan 2009 00:48:53 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Stone <michael@laptop.org> writes:

> For the sake of discussion, I have written up and documented one possible
> implementation of this concept based on the idea of a new rlimit named
> RLIMIT_NETWORK in the following patch series. 
>
> I eagerly await your questions, comments, suggestions, and improvements.

At least for outgoing packets you could already do it using the netfilter
owner match and a suitable uid. I suppose that could be also extended
for incoming packets.

-Andi
-- 
ak@linux.intel.com
