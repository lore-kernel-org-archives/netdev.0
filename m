From: Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC 0/5] Containerize syslog
Date: Wed, 21 Nov 2012 17:35:27 +0800
Message-ID: <50ACA05F.7080005@gmail.com>
References: <50A9EAD8.9090501@gmail.com>
	<20121119143702.GB4620@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121119143702.GB4620-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2012-11-19 22:37, Serge E. Hallyn wrote:
> Quoting Rui Xiang (leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
>> From: Xiang Rui <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>
>> In Serge's patch (http://lwn.net/Articles/525629/), syslog_namespace was tied to a user
>> namespace. We add syslog_ns tied to nsproxy instead, and implement ns_printk in
>> ip_table context.
> 
> Since you say 'we', I'm just wondering, which project is this a part of?
> 

Hi,Serge

Thank you for your attention.

We may use container in our company, and one of the missing part we found is syslog
isolation (though we require this feature or not is not sure at this moment), so we
made this patchset.

>> We add syslog_namespace as a part of nsproxy, and a new flag CLONE_SYSLOG to unshare
>> syslog area.
> 
> Thanks, looks like you save me the time of having to add some users of
> nsprintk :)
> 
> I understand that user namespaces aren't 100% usable yet, but looking
> long term, is there a reason to have the syslog namespace separate
> from user namespace?

Actually we don't have strong preference. We'll think more about it. Hope we can make
consensus with Eric.

Thanks,
Rui Xiang
