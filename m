From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 1/2] Define security_sk_getsecctx
Date: Wed, 31 Aug 2011 14:46:01 -0400
Message-ID: <1314816361.6850.51.camel@moss-pluto>
References: <1314779777-12669-1-git-send-email-rongqing.li@windriver.com>
	 <1314779777-12669-2-git-send-email-rongqing.li@windriver.com>
	 <4E5E568A.4050407@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rongqing.li@windriver.com, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4E5E568A.4050407@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-08-31 at 08:43 -0700, Casey Schaufler wrote:
> On 8/31/2011 1:36 AM, rongqing.li@windriver.com wrote:
> > From: Roy.Li <rongqing.li@windriver.com>
> >
> > Define security_sk_getsecctx to return the security
> > context of a sock.
> 
> So, what is the intended use of the information
> coming from this hook? If I wanted to write the
> Smack hook, which of the "contexts" would I want
> to return? There are potentially three. If I know
> what the caller is looking for, I can (hopefully)
> select the correct information.

The initial use case is for netstat -Z so that it can reliably show the
security context of the socket rather than inferring it from the owning
process, which can be inaccurate for security-aware applications.

In your situation, when in != out, which would you rather see in netstat
-Z output?  Alternatively, if you want them both, perhaps you could
combine in and out into a single string that is returned, similar to
what you proposed for handling multiple xattrs with inode_getsecctx()?

-- 
Stephen Smalley
National Security Agency

