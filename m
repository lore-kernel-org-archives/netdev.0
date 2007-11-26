From: Paul Moore <paul.moore@hp.com>
Subject: Re: Missing audit information in xfrm_audit_common_policyinfo()?
Date: Mon, 26 Nov 2007 11:52:03 -0500
Message-ID: <200711261152.03686.paul.moore@hp.com>
References: <OFDEF5C6F1.0AEFC4FF-ON8725739F.005BF832-8625739F.005C2038@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com
To: Joy Latten <latten@us.ibm.com>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <OFDEF5C6F1.0AEFC4FF-ON8725739F.005BF832-8625739F.005C2038@us.ibm.com>
Content-Disposition: inline
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Monday 26 November 2007 11:47:09 am Joy Latten wrote:
> Paul Moore <paul.moore@hp.com> wrote on 11/21/2007 03:34:31 PM:
> > I just noticed that the IPsec auditing code does not appear to audit the
> >
> > netmask for the selector source and destination addresses in
> > xfrm_audit_common_policyinfo().  Before I threw a patch together I
>
> thought I
>
> > would check to see if there was a reason for this that I am missing ...
>
> I don't think we ever discussed including netmask when we added the
> ipsec audit info...

Hmmm ... okay.  I'm almost certain it should be included when auditing changes 
to the SPD as the netmask/prefixlen is very important when considering which 
traffic will be matched by a particular SPD entry.

I'm working on a patch now.

-- 
paul moore
linux security @ hp
