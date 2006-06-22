From: James Morris <jmorris@namei.org>
Subject: Re: [RFC 2/7] NetLabel: core network changes
Date: Thu, 22 Jun 2006 14:58:33 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606221457520.21897@d.namei>
References: <20060621194234.979661000@flek.zko.hp.com>
 <20060621200030.880930000@flek.zko.hp.com> <20060622.020055.115910616.davem@davemloft.net>
 <200606221105.00331.sgrubb@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="537530981-932703160-1151002713=:21897"
Cc: David Miller <davem@davemloft.net>, paul.moore@hp.com,
	redhat-lspp@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	sds@epoch.ncsc.mil, jmorris@redhat.com
Return-path: <linux-security-module-owner@vger.kernel.org>
To: Steve Grubb <sgrubb@redhat.com>
In-Reply-To: <200606221105.00331.sgrubb@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--537530981-932703160-1151002713=:21897
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 22 Jun 2006, Steve Grubb wrote:

> On Thursday 22 June 2006 05:00, David Miller wrote:
> > >  #define NETLINK_GENERIC              16
> > > +#define NETLINK_NETLABEL     17      /* Network packet labeling */
> > >  
> > >  #define MAX_LINKS 32         
> >
> > Please use generic netlink.
> 
> Since this is a security interface, shouldn't it be its own protocol so that 
> SE Linux can control commands being sent? Paul's patches do include a netlink 
> table in security/selinux/nlmsgtab.c. But I do not see any hooks to control 
> generic netlink messages. (There seems to be several protocols that SE Linux 
> is not controlling.) I could see that someone in secadm role should be able 
> to issue these commands, but someone at sysadm or auditadm would not.
> 
> If moving this over to generic is a must, then I think SE Linux will have to 
> clip into generic to control its packet flow.

SELinux will mediate them as 'generic' netlink.

Fine-grained SELinux support for generic netlink is todo.



-- 
James Morris
<jmorris@namei.org>
--537530981-932703160-1151002713=:21897--
