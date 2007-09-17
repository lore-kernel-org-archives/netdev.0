From: "Peter Waskiewicz" <pjwaskiewicz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-2.6.24][patch 2/2] Dynamically allocate the loopback device
Date: Mon, 17 Sep 2007 12:12:24 -0700
Message-ID: <224b7d320709171212o66734847kbd17efa817b482fc@mail.gmail.com>
References: <20070917134509.222896190@mai.toulouse-stg.fr.ibm.com>
	<20070917135133.466924283@mai.toulouse-stg.fr.ibm.com>
	<20070917101314.5d1673da@freepuppy.rosehill.hemminger.net>
	<46EECCD5.5090601@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5665050648372599857=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
        Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
To: "Daniel Lezcano" <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46EECCD5.5090601-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============5665050648372599857==
Content-Type: multipart/alternative;
	boundary="----=_Part_17566_25653737.1190056344050"

------=_Part_17566_25653737.1190056344050
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This would be a good opportunity to remove the single-allocated queue struct
in netdevice (at the bottom) that we had to put in to accomodate the static
loopback.  Now we can set it back to a zero element list, and have
alloc_netdev_mq() just allocate the number of queues requested, not
num_queues - 1.

I'll put a patch together based on this patchset.

Thanks,
-PJ Waskiewicz

------=_Part_17566_25653737.1190056344050
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This would be a good opportunity to remove the single-allocated queue struct in netdevice (at the bottom) that we had to put in to accomodate the static loopback.&nbsp; Now we can set it back to a zero element list, and have alloc_netdev_mq() just allocate the number of queues requested, not num_queues - 1.
<br><br>I&#39;ll put a patch together based on this patchset.<br><br>Thanks,<br>-PJ Waskiewicz<br>

------=_Part_17566_25653737.1190056344050--

--===============5665050648372599857==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============5665050648372599857==--
