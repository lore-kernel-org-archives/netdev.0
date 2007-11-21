From: Paul Moore <paul.moore@hp.com>
Subject: Missing audit information in xfrm_audit_common_policyinfo()?
Date: Wed, 21 Nov 2007 16:34:31 -0500
Message-ID: <200711211634.31499.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-audit@redhat.com, netdev@vger.kernel.org,
	Joy Latten <latten@us.ibm.com>
Return-path: <linux-audit-bounces@redhat.com>
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

I just noticed that the IPsec auditing code does not appear to audit the 
netmask for the selector source and destination addresses in 
xfrm_audit_common_policyinfo().  Before I threw a patch together I thought I 
would check to see if there was a reason for this that I am missing ...

-- 
paul moore
linux security @ hp
