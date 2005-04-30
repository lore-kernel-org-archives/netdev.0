From: jamal <hadi@cyberus.ca>
Subject: Re: patch2: del/get byid
Date: Fri, 29 Apr 2005 21:08:12 -0400
Message-ID: <1114823293.8929.44.camel@localhost.localdomain>
References: <20050428030325.GB23823@gondor.apana.org.au>
	 <1114658657.7663.110.camel@localhost.localdomain>
	 <1114698033.7663.197.camel@localhost.localdomain>
	 <20050428231154.GA14215@gondor.apana.org.au>
	 <1114779104.7800.22.camel@localhost.localdomain>
	 <1114816846.8929.6.camel@localhost.localdomain>
	 <20050429234952.GB22699@gondor.apana.org.au>
	 <1114819281.8929.9.camel@localhost.localdomain>
	 <20050430001248.GA22927@gondor.apana.org.au>
	 <1114821357.8929.27.camel@localhost.localdomain>
	 <20050430004715.GA23429@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050430004715.GA23429@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-30-04 at 10:47 +1000, Herbert Xu wrote:
> On Fri, Apr 29, 2005 at 08:35:57PM -0400, jamal wrote:
> >
> > > 1) You find delpol using xfrm_policy_byid/xfrm_policy_bysel.
> > 
> > Which increments the refcnt
> 
> Refcnt prevents the policy from being freed.  It doesn't prevent it
> from being deleted from the list.  Only the list lock can do that.
> 

Yes, of course. Look at the code carefuly,  the delpol is already
_unlinked_ when i call xfrm_policy_kill();-> 
If it wasnt so none of those tests would have worked; infact in my first
30 seconds of testing i discovered that when i listed after
an update;->

cheers,
jamal
