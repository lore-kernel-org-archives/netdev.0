From: Klaus Weidner <klaus@atsec.com>
Subject: Re: Re: [RFC 3/7] NetLabel: CIPSOv4 engine
Date: Tue, 27 Jun 2006 14:41:42 -0500
Message-ID: <20060627194142.GC5181@w-m-p.com>
References: <20060621194234.979661000@flek.zko.hp.com>
	<20060621200031.589235000@flek.zko.hp.com>
	<20060622.021223.125894633.davem@davemloft.net>
	<F5329247-1566-4989-954B-A199240DC89F@nall.com>
	<Pine.LNX.4.64.0606262031010.26545@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Nall <joe@nall.com>, jmorris@redhat.com,
	Paul Moore <paul.moore@hp.com>, Stephen Smalley <sds@epoch.ncsc.mil>,
	RedHat LSPP <redhat-lspp@redhat.com>,
	linux-security-module@vger.kernel.org,
	SELinux List <selinux@tycho.nsa.gov>, netdev@vger.kernel.org,
	Steve Grubb <sgrubb@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <redhat-lspp-bounces@redhat.com>
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0606262031010.26545@d.namei>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/redhat-lspp>
List-Post: <mailto:redhat-lspp@redhat.com>
List-Help: <mailto:redhat-lspp-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=subscribe>
Sender: redhat-lspp-bounces@redhat.com
Errors-To: redhat-lspp-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 26, 2006 at 08:33:57PM -0400, James Morris wrote:
> On Mon, 26 Jun 2006, Joe Nall wrote:
> > For all of the EAL4 LSPP Linux evaluation work is being done by Red
> > Hat/IBM/HP/atsec and others to be useful to integrators, there has to be basic
> > (e.g. CIPSO) multilevel network interoperability with existing multilevel
> > systems and good (e.g IPSec) multilevel networking between SELinux systems.
> 
> Just to be clear, my understanding is that the native xfrm labeling is 
> suitable for LSPP evaluation, as distinct from CIPSO being desired by 
> system integrators from an interoperability point of view.

It's not quite that distinct, the two solutions overlap in some areas but
neither can replace the other.

CIPSO would also be suitable for LSPP evaluation since it is capable of
exporting and importing labeled data. It requires a trusted network since
it doesn't encrypt or authenticate, so the evaluation would need to
restrict the environment accordingly.

The native IPSEC/xfrm approach is useful for more hostile environments
where you can't fully trust the network, but it's not interoperable with
existing deployed systems so it's not a replacement for CIPSO.

>From an evaluation point of view, either CIPSO or IPSEC/xfrm would be
able to meet LSPP requirements but with different restrictions on the
environment.

-Klaus
