From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 8/8] net: Implement socketat.
Date: Thu, 23 Sep 2010 16:34:37 +0400
Message-ID: <4C9B495D.70200@parallels.com>
References: <m1ocborgq7.fsf@fess.ebiederm.org>	
	<m1bp7oq1u8.fsf@fess.ebiederm.org>
	<4C9B162E.7040201@parallels.com>	
	<1285240797.5036.5.camel@bigi> <4C9B3B06.900@parallels.com>	
	<1285242055.5036.9.camel@bigi> <4C9B3F9C.8080506@parallels.com>
	<1285243881.5036.22.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Ulrich Drepper <drepper-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
        Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1285243881.5036.22.camel@bigi>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/23/2010 04:11 PM, jamal wrote:
> On Thu, 2010-09-23 at 15:53 +0400, Pavel Emelyanov wrote:
> 
>> Why does it matter? You told, that the usage scenario was to
>> add routes to container. If I do 2 syscalls instead of 1, is
>> it THAT worse?
>>
> 
> Anything to do with socket IO that requires namespace awareness
> applies for usage; it could be tcp/udp/etc socket. If it doesnt
> make any difference performance wise using one scheme vs other
> to write/read heavy messages then i dont see an issue and socketat
> is redundant.

That's what my point is about - unless we know why would we need it
we don't need it.

Eric, please clarify, what is the need in creating a socket in foreign
net namespace?
