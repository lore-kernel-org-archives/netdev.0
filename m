From: David Collier-Brown <davecb@sun.com>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 08:46:51 -0400
Message-ID: <4810813B.6010604@sun.com>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
 <517f3f820804240527l66e4372dt9d6cdc293e35899d@mail.gmail.com>
Reply-To: davecb@sun.com
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: Ulrich Drepper <drepper@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: Michael Kerrisk <mtk.manpages@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759308AbYDXMsy@vger.kernel.org>
In-reply-to: <517f3f820804240527l66e4372dt9d6cdc293e35899d@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  Just FYI, if you end up looking at having to make lots of changes to a 
(probably user-side) interface, I did an open-source version of the
"score" fast-porting tool, described at http://datacenterworks.com/stories/port.html

It makes fixing annoying API changes somewhat less evil (;-))

--dave (at work) c-b

Michael Kerrisk wrote:
> On 4/24/08, Ulrich Drepper <drepper@redhat.com> wrote:
> 
>>The alternative to using sys_indirect is to create a whole bunch of new
>> syscalls.  Here the beginning.  These are the socket interfaces which
>> create file descriptors and therefore need a flags parameter to let
>> the caller decide about setting the close-on-exit bit.
> 
> 
> Ulrich,
> 
> Could you please CC me on patches that make kernel-userland API changes.
> 
> Cheers,
> 
> Michael
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

-- 
David Collier-Brown            | Always do right. This will gratify
Sun Microsystems, Toronto      | some people and astonish the rest
davecb@sun.com                 |                      -- Mark Twain
(905) 943-1983, cell: (647) 833-9377, (800) 555-9786 x56583
bridge: (877) 385-4099 code: 506 9191#
