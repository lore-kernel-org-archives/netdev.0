From: "=?iso-8859-15?q?R=E9mi?= Denis-Courmont" <remi-AzDNUFsAnHasTnJN9+BGXg@public.gmane.org>
Subject: Re: [PATCH 2/7] ns: Introduce the setns syscall
Date: Sat, 7 May 2011 11:01:08 +0300
Message-ID: <201105071101.10950.remi@remlab.net>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<1304735101-1824-1-git-send-email-ebiederm@xmission.com>
	<1304735101-1824-2-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1304735101-1824-2-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

Le samedi 7 mai 2011 05:24:56 Eric W. Biederman, vous avez =E9crit :
> Pieces of this puzzle can also be solved by instead of
> coming up with a general purpose system call coming up
> with targed system calls perhaps socketat that solve
> a subset of the larger problem.  Overall that appears
> to be more work for less reward.

socketat() is still required for multithreaded namespace-aware userspace, I =

believe.

-- =

R=E9mi Denis-Courmont
http://www.remlab.info/
http://fi.linkedin.com/in/remidenis
