From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/8] user_ns: Introduce user_nsmap_uid and user_ns_map_gid.
Date: Tue, 15 Jun 2010 12:02:17 +0400
Message-ID: <4C173389.1010000@openvz.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>	<m1d3vvhxlj.fsf@fess.ebiederm.org>
	<m17hm3hxjw.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m17hm3hxjw.fsf_-_-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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

On 06/13/2010 05:28 PM, Eric W. Biederman wrote:
> 
> Define what happens when a we view a uid from one user_namespace
> in another user_namepece.
> 
> - If the user namespaces are the same no mapping is necessary.
> 
> - For most cases of difference use overflowuid and overflowgid,
>   the uid and gid currently used for 16bit apis when we have a 32bit uid
>   that does fit in 16bits.  Effectively the situation is the same,
>   we want to return a uid or gid that is not assigned to any user.
> 
> - For the case when we happen to be mapping the uid or gid of the
>   creator of the target user namespace use uid 0 and gid as confusing
>   that user with root is not a problem.
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

I suppose this one should go via Andrew, not Dave.

Anyway, Acked-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
