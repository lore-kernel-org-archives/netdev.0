From: "Alec H. Peterson" <ahp@hilander.com>
Subject: Re: PCI memory reservation failure - 2.4/2.6
Date: Mon, 17 May 2004 07:49:34 -0600
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20D3F7A6CA3A4C9FF0E47D1A@[192.168.0.100]>
References: <BDD74A21E0B47FEAC3AB8A10@[192.168.0.100]>
 <40A29211.2010707@colorfullife.com>
 <9C9F57570B19C8A682D96940@[192.168.0.100]>
 <40A670D9.5010409@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Dominik Brodowski <linux@brodo.de>,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S261378AbUEQNtg@vger.kernel.org>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <40A670D9.5010409@colorfullife.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

--On Saturday, May 15, 2004 9:34 PM +0200 Manfred Spraul 
<manfred@colorfullife.com> wrote:

>
> There are two possible approaches:
> - just a module parameter. Probably something for 2.4.
> - a combination of a dmi detection of buggy bios versions plus a pci
> quirk that resets start and end to 0.
>
> Attached is the module parameter patch against 2.6. If it works I can
> write a backport to 2.4 and try to convince Marcelo to merge it.
> Could you send me the output of dmidecode? I'll try to write the
> autodetection patch for 2.6.

I'm actually sticking with 2.4 for right now, which I'd be more than happy 
to test on.  How different would your patch be for 2.4?

I am unfamiliar with dmidecode, I am afraid.

If you can't get the requisite info for 2.6 I would be happy to move one of 
my systems with the issue over to it to get the info.  Please let me know.

FWIW I saw a post from somebody on netdev and madwifi-users who says he is 
using your 2.6 patch with no problems.

Alec
