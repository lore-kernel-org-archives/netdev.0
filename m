From: Joe Nall <joe@nall.com>
Subject: Re: [redhat-lspp] Re: [RFC 3/7] NetLabel: CIPSOv4 engine
Date: Mon, 26 Jun 2006 18:14:12 -0500
Message-ID: <F5329247-1566-4989-954B-A199240DC89F@nall.com>
References: <20060621194234.979661000@flek.zko.hp.com> <20060621200031.589235000@flek.zko.hp.com> <20060622.021223.125894633.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v750)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul.moore@hp.com>, jmorris@redhat.com,
	Stephen Smalley <sds@epoch.ncsc.mil>,
	RedHat LSPP <redhat-lspp@redhat.com>,
	linux-security-module@vger.kernel.org,
	SELinux List <selinux@tycho.nsa.gov>, netdev@vger.kernel.org,
	Steve Grubb <sgrubb@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp112.sbc.mail.mud.yahoo.com ([68.142.198.211]:34395 "HELO
	smtp112.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S933249AbWFZXOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 19:14:35 -0400
In-Reply-To: <20060622.021223.125894633.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jun 22, 2006, at 4:12 AM, David Miller wrote:

> From: paul.moore@hp.com
> Date: Wed, 21 Jun 2006 15:42:38 -0400
>
>> Add support for the Commercial IP Security Option (CIPSO) to the
>> IPv4 network stack.  CIPSO has become a de-facto standard for
>> trusted/labeled networking amongst existing Trusted Operating
>> Systems such as Trusted Solaris, HP-UX CMW, etc.  This
>> implementation is designed to be used with the NetLabel subsystem to
>> provide explicit packet labeling to LSM developers.
>
> The thing that concerns me most about CIPSO is that even once users
> migrate to a more SELINUX native approach from this CIPSO stuff, the
> CIPSO code, it's bloat, and it's maintainence burdon will remain.
>
> It's easy to put stuff it, it's impossible to take stuff out even
> once it's largely unused by even it's original target audience.
>
> And that's what I see happening here.
>
> This is why, to be perfectly honest with you, I'd much rather
> something like this stay out-of-tree and people are strongly
> encouraged to use the more native stuff under Linux.

We are looking to replace a number of 20-60 node CMW networks with  
lots of applications with an SELinux based network. Since mainstream  
support for multilevel X Windows appears a ways off,  we are looking  
to replace the servers first and use the current CMWs as fat clients.  
To make this work we need multilevel networking interoperability  
between the SELinux and CMW systems.

We have been testing Paul's CIPSO patch against our existing systems  
with good results.

For all of the EAL4 LSPP Linux evaluation work is being done by Red  
Hat/IBM/HP/atsec and others to be useful to integrators, there has to  
be basic (e.g. CIPSO) multilevel network interoperability with  
existing multilevel systems and good (e.g IPSec) multilevel  
networking between SELinux systems. Without that support, it will be  
like some early Microsoft evaluations (1,2) that were reported to  
have been done 'without a network card', a piece of paper describing  
the test of a brick.

joe

(1) http://support.novell.com/techcenter/articles/ana19970705.html  
(search for 'without')
(2) http://www.aaxnet.com/design/msanti.html (search for 'did not  
have a network card')
