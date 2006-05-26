From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC 0/4] NetLabel
Date: Fri, 26 May 2006 12:34:33 -0400
Message-ID: <44772E19.5030907@hp.com>
References: <44760E29.4070407@hp.com> <Pine.LNX.4.64.0605251938360.27473@d.namei> <44771EFB.6030203@hp.com> <Pine.LNX.4.64.0605261156030.3103@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, James Morris <jmorris@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <linux-security-module-owner@vger.kernel.org>
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0605261156030.3103@d.namei>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Fri, 26 May 2006, Paul Moore wrote:
>>>- Why does this module have a version number?
>>>
>>>+       printk(KERN_INFO "NetLabel: Initializing (v%s %s)\n",
>>>+              NETLBL_VER_STR, NETLBL_VER_DATE);
>>>
>>
>>The version number is there primarily to help signal possible
>>differences in the NetLabel netlink protocol.
> 
> How will this ever help anything?
> 
> If you change that protocol, userspace applications will break, which is 
> not acceptable.  You can add versioning at the protocol level or via 
> adding a new netlink family in the future, but existing apps cannot break 
> and you need to maintain compatibility.
> 

The NetLabel netlink protocol does have a "version" message which can be
used to get the version.  My main reason for doing this is not to signal
changes to existing messages, i.e. break backward compatability, but to
signal to user space applications that the kernel supports a newer protocol.

The printk() above is just informative, if that is your main concern I
can yank it.

-- 
paul moore
linux security @ hp
