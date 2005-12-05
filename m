From: Joseph Jezak <josejx-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: Re: Broadcom 43xx first results
Date: Mon, 05 Dec 2005 13:38:37 -0500
Message-ID: <4394892D.2090100@gentoo.org>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de> <20051205190038.04b7b7c1@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
   bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
In-Reply-To: <20051205190038.04b7b7c1-IhiK2ZEFs2oCVLCxKZUutA@public.gmane.org>
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

 > Why yet another attempt to write 802.11 stack? Sure, the one currently
 > in the kernel is unusable and everybody knows about it. But why not to
 > improve code opensourced by Devicescape some time ago instead of
 > inventing the wheel again and again? Yes, I know that code is not
 > perfect and needs a lot of work, but it is the best piece of code we
 > have available now. And it _does_ support WPA and such - in fact, it
 > is nearly complete.
 >
 > Please take a look at http://kernel.org/pub/linux/kernel/people/jbenc/

We're not writing an entire stack.  We're writing a layer that sits in 
between the current ieee80211 stack that's already present in the kernel 
and drivers that do not have a hardware MAC.  Since ieee80211 is already 
in use in the kernel today, this seemed like a natural and useful 
extension to the existing code.  I agree that it's somewhat wasteful to 
keep rewriting 802.11 stacks and we considered other options, but it 
seemed like a more logical choice to work with what was available and 
recommended than to use an external stack.

-Joe
