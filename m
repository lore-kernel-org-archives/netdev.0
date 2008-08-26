From: Joe Nall <joe@nall.com>
Subject: Re: [RFC PATCH v3 00/13] Labeled networking patches for 2.6.28
Date: Tue, 26 Aug 2008 10:47:37 -0500
Message-ID: <374F28B6-E756-4E7C-BC5E-66757D689955@nall.com>
References: <20080821210239.7951.59652.stgit@flek.lan>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Paul Moore <paul.moore@hp.com>
To: SE Linux <selinux@tycho.nsa.gov>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080821210239.7951.59652.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Aug 21, 2008, at 4:25 PM, Paul Moore wrote:

> Another update to the labeled networking patches for 2.6.28.  This  
> revision
> adds some small fixes, the dead-code removal patch posted earlier,  
> and the big
> addition ... wait for it ... full LSM label/context support for local
> connections.  This is accomplished by creating a new, private CIPSO  
> tag type
> (allowed by the spec with a tag number > 127) which carries the  
> LSM's secid
> value, allowing full LSM contexts to be carried across local  
> connections
> without the headaches of labeled IPsec.
>
> For those of you interested in testing this out, you will need the  
> latest
> from the netlabel_tools addrsel branch, revision 74 or higher should  
> work.
> If you enable the new local labeling you will almost certainly need  
> to run
> SELinux in permissive mode since I'm fairly certain the current  
> policies don't
> have the necessary allow rules.  With that said, enabling the new  
> local
> labeling is pretty easy ...

Paul created a 2.6.26 patch which I've been testing with excellent  
results in Fedora 9. Local (lo and ethN) labeled networking is more  
reliable than the IPSec equivalent and does not have the IPSec SA  
creation latency. I'll push this to a larger set of developers and  
testers next week and report any issues.

joe

