From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Fastboot] Re: Re: tg3: issue for reboot/kexec
Date: Thu, 30 Jun 2005 19:27:51 -0600
Message-ID: <m1r7ejjox4.fsf@ebiederm.dsl.xmission.com>
References: <42BC9F09.1060002@us.ibm.com>
	<20050624174652.159f26ce.rdunlap@xenotime.net>
	<20050625033328.GC3934@kroah.com>
	<m18y0rl9bq.fsf@ebiederm.dsl.xmission.com>
	<42C499DD.3050009@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============74603266690478365=="
Cc: linux-pm@lists.osdl.org, fastboot@lists.osdl.org, netdev@vger.kernel.org
Return-path: <linux-pm-bounces@lists.osdl.org>
To: Haren Myneni <haren@us.ibm.com>
In-Reply-To: <42C499DD.3050009@us.ibm.com> (Haren Myneni's message of "Thu,
	30 Jun 2005 18:18:21 -0700")
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============74603266690478365==
Content-Type: text/plain; charset=us-ascii

Haren Myneni <haren@us.ibm.com> writes:

> Eric W. Biederman wrote:
>
>>A couple stray bits of feedback.  Downing the interface is generally
>>a user space requirement like unmounting filesystems.
>>/sbin/kexec and /sbin/reboot both perform this operation so I don't
>>see how this bug was hit.
>>
>>
>>
> Thanks for your feedback. We are still working on kexec tools for PPC64. In the
> mean time, I was using a temporary tool which does not do ifdown. I was in the
> impression that the kexec boot will be successful since the normal kexec code
> path (kernel/sys.c) contains device_shutdown/reboot notifier. It turns out I am
> wrong.

Buggy drivers will do that to you as well.  But not doing a clean shutdown
(downing interfaces, and unmounting the filesystems) doesn't help things  :)

Eric

--===============74603266690478365==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


--===============74603266690478365==--
