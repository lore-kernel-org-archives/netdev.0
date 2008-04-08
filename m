From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH 2/2] LSM: Make the Labeled IPsec hooks more stack friendly
Date: Tue, 8 Apr 2008 17:01:48 -0400
Message-ID: <200804081701.48667.paul.moore@hp.com>
References: <20080407231143.8087.77531.stgit@flek.lan> <20080407231635.8087.42161.stgit@flek.lan> <1207650292.30750.43.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: hadi@cyberus.ca
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1207650292.30750.43.camel@localhost>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 08 April 2008 6:24:52 am jamal wrote:
> On Mon, 2008-07-04 at 19:16 -0400, Paul Moore wrote:
> > The xfrm_get_policy() and xfrm_add_pol_expire() put some rather
> > large structs on the stack to work around the LSM API.
>
> You missed a spot which applies similar logic:
> net/key/af_key.c::pfkey_spddelete()

Thanks, I'll check all the pfkey bits to see if anything else jumps out 
too ... and figure out why my config wasn't building pfkey :)

-- 
paul moore
linux @ hp
