From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC PATCH net-next 1/4] net: introduce backup_classid to
	struct skbuff
Date: Fri, 03 Jan 2014 00:34:04 -0500 (EST)
Message-ID: <20140103.003404.1439874071277993396.davem@davemloft.net>
References: <52C62A48.1050604@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <52C62A48.1050604-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Date: Fri, 3 Jan 2014 11:11:04 +0800

> 
> introduce backup_classid to struct skbuff,
> we can use it to backup sk_classid when net_ns switch.
> 
> Signed-off-by: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Sorry, no new sk_buff members unless there is absolutely not other
possible implementation.

sk_buff is too big as-is.
