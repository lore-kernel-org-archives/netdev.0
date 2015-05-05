From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace
	instances
Date: Tue, 05 May 2015 09:56:03 -0500
Message-ID: <87pp6fhy4c.fsf@x220.int.ebiederm.org>
References: <cover.1429252659.git.rgb@redhat.com>
	<11270b0b1afd0a25b108915673e1e1b38dfeeafa.1429252659.git.rgb@redhat.com>
	<2487286.y6vyJ9A3er@x2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2487286.y6vyJ9A3er@x2> (Steve Grubb's message of "Tue, 05 May
	2015 10:22:32 -0400")
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

Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> The requirements for auditing of containers should be derived from VPP. In it, 
> it asks for selectable auditing, selective audit, and selective audit review. 
> What this means is that we need the container and all its children to have one 
> identifier that is inserted into all the events that are associated with the 
> container.

That is technically impossible.  Nested containers exist.

That is when container G is nested in container F which is in turn
nested in container E which is in turn nested in container D which is in
turn nested in container C which is in turn nested in container B which
is nested in container A there is no one label you can put on audit
messages from container G which is the ``correct'' one.

Or are you proposing that something in container G have labels
A B C D E F G included on every audit message?   That introduces enough
complexity in generating and parsing the messages I wouldn't trust those
messages as the least bug in generation and parsing would be a security
issue.

What is the world is VPP?  It sounds like something non-public thing.
Certainly it has never been a part of the public container discussion
and as such it appears to be completely ridiculous to bring up in a
public discussion.

Eric
