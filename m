From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: kmemcheck detected possible information leak to userspace?
Date: Tue, 1 Jul 2008 15:08:09 +0300
Message-ID: <84144f020807010508o1332fab8rfd6bd050a6e56eb9@mail.gmail.com>
References: <19f34abd0807010216k11a60382xf7a27b4b27f0819@mail.gmail.com>
	 <20080701102459.GB30248@2ka.mipt.ru>
	 <19f34abd0807010352t264fda16g826912a857e88140@mail.gmail.com>
	 <87skutu8pw.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Vegard Nossum" <vegard.nossum@gmail.com>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	"Ingo Molnar" <mingo@elte.hu>, linux-kernel@vger.kernel.org
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755877AbYGAMIW@vger.kernel.org>
In-Reply-To: <87skutu8pw.fsf@basil.nowhere.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andi,

"Vegard Nossum" <vegard.nossum@gmail.com> writes:
>> But there is one thing I forgot: Is this memory initialized by DMA? If
>> so, the warning is bogus and I will go hide in shame.

On Tue, Jul 1, 2008 at 2:47 PM, Andi Kleen <andi@firstfloor.org> wrote:
> Yes it is.
>
> [btw that was something I noted during the initial review and was then
> ridiculed for]

Yes, you pointed that out but we sure as hell didn't ridicule you for
it. I even explicitly said that we're probably missing kmemcheck
annotations from other similar places as well (not just networking).
