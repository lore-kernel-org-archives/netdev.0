From: Greg KH <greg@kroah.com>
Subject: Re: [Fastboot] Re: Re: tg3: issue for reboot/kexec
Date: Thu, 30 Jun 2005 16:33:55 -0700
Message-ID: <20050630233354.GA22287@kroah.com>
References: <42BC9F09.1060002@us.ibm.com>
	<20050624174652.159f26ce.rdunlap@xenotime.net>
	<20050625033328.GC3934@kroah.com>
	<m18y0rl9bq.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1533575847681794=="
Cc: netdev@vger.kernel.org, fastboot@lists.osdl.org, linux-pm@lists.osdl.org
Return-path: <linux-pm-bounces@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m18y0rl9bq.fsf@ebiederm.dsl.xmission.com>
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

--===============1533575847681794==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 30, 2005 at 05:21:45PM -0600, Eric W. Biederman wrote:
> However I have gotten feedback a couple of times that
> driver writers tend to prefer using reboot notifiers.  In part
> because shutdown functions don't exist for non-pci devices.

That's a very lame excuse.  All busses should have shutdown functions.
And any device that is just bypassing all of the existing bus logic is
still tying into the driver core directly (which is a bad thing by
itself, but that's a different matter.)  And there's a shutdown method
there too.

So there is no excuse to not use it.  Please, if they complain, point
them to me :)

thanks,

greg k-h

--===============1533575847681794==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


--===============1533575847681794==--
