From: Khalid Aziz <khalid_aziz@hp.com>
Subject: Re: [Fastboot] Re: Re: tg3: issue for reboot/kexec
Date: Thu, 18 Aug 2005 13:06:05 -0600
Message-ID: <1124391965.2274.17.camel@lyra.fc.hp.com>
References: <42BC9F09.1060002@us.ibm.com>
	<20050624174652.159f26ce.rdunlap@xenotime.net>
	<20050625033328.GC3934@kroah.com>
	<m18y0rl9bq.fsf@ebiederm.dsl.xmission.com>
	<20050630233354.GA22287@kroah.com>
	<m1vf3vjtbc.fsf@ebiederm.dsl.xmission.com>
	<1124389821.2274.11.camel@lyra.fc.hp.com>
	<m1wtmjulxe.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============42281730325357136=="
Cc: linux-pm@lists.osdl.org, Fastboot mailing list <fastboot@lists.osdl.org>,
   netdev@vger.kernel.org
Return-path: <linux-pm-bounces@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1wtmjulxe.fsf@ebiederm.dsl.xmission.com>
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

--===============42281730325357136==
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2005-08-18 at 12:42 -0600, Eric W. Biederman wrote:
> Khalid Aziz <khalid_aziz@hp.com> writes:
> > As soon as I have all the issues sorted out with kexec'ing on INIT on
> > ia64, I will post a fully updated kexec patch for ia64. I now have kexec
> > working solid on INIT with e1000 driver and it can handle multiple back
> > to back INITs and come up in kexec'd kernel every time. I am now trying
> > to sort some issues out with tg3 driver (another driver with no shutdown
> > routine :(
> 
> In the normal case (not kexec on panic) user space should down the interfaces
> before calling kexec.  Is your user space doing that?

Yes, I am down'ing the interface from userspace in normal kexec case,
but that does not happen on INIT on ia64. 

-- 
Khalid

====================================================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini


--===============42281730325357136==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


--===============42281730325357136==--
