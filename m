From: Eugene Teo <eugeneteo@kernel.org>
Subject: Re: [PATCH v2] kptr_restrict for hiding kernel pointers from unprivileged
 users
Date: Wed, 15 Dec 2010 12:18:12 +0800
Message-ID: <4D084184.7090808@kernel.org>
References: <1292385983.9764.5.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Kees Cook <kees.cook@canonical.com>,
	Eugene Teo <eugeneteo@kernel.org>,
	James Morris <jmorris@namei.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1292385983.9764.5.camel@Dan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/15/2010 12:06 PM, Dan Rosenberg wrote:
> The below patch adds the %pK format specifier, the
> CONFIG_SECURITY_KPTR_RESTRICT configuration option, and the
> kptr_restrict sysctl.
>
> The %pK format specifier is designed to hide exposed kernel pointers
> from unprivileged users, specifically via /proc interfaces.  Its
> behavior depends on the kptr_restrict sysctl, whose default value
> depends on CONFIG_SECURITY_KPTR_RESTRICT.  If kptr_restrict is set to 0,
> no deviation from the standard %p behavior occurs.  If kptr_restrict is
> set to 1, if the current user (intended to be a reader via seq_printf(),
> etc.) does not have CAP_SYSLOG (which is currently in the LSM tree),
> kernel pointers using %pK are printed as 0's.  This was chosen over the
> default "(null)", which cannot be parsed by userland %p, which expects
> "(nil)".
>
> v2 improves checking for inappropriate context, on suggestion by Peter
> Zijlstra.  Thanks to Thomas Graf for suggesting use of a centralized
> format specifier.
>
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
> CC: James Morris <jmorris@namei.org>
> CC: Eugene Teo <eugeneteo@kernel.org>
> CC: Kees Cook <kees.cook@canonical.com>
> CC: Ingo Molnar <mingo@elte.hu>
> CC: David S. Miller <davem@davemloft.net>
> CC: linux-security-module@vger.kernel.org
> CC: netdev@vger.kernel.org

Acked-by: Eugene Teo <eugeneteo@kernel.org>

Eugene
