From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH net] bridge: Only call /sbin/bridge-stp for the
 initial network namespace
Date: Mon, 30 Nov 2015 23:57:29 +0100
Message-ID: <565CD459.6010402@nod.at>
References: <565B7F7D.80208@nod.at>
	<CAGXu5jJqQKAmFK0nL69E0QOpo8WSVDqStGZo7-m7gy3vnXBa=A@mail.gmail.com>
	<87egf7183c.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>, "kernel-hardening@lists.openwall.com"
	<kernel-hardening@lists.openwall.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <87egf7183c.fsf_-_@x220.int.ebiederm.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Am 30.11.2015 um 22:38 schrieb Eric W. Biederman:
> 
> There is no defined mechanism to pass network namespace information
> into /sbin/bridge-stp therefore don't even try to invoke it except
> for bridge devices in the initial network namespace.
> 
> It is possible for unprivileged users to cause /sbin/bridge-stp to be
> invoked for any network device name which if /sbin/bridge-stp does not
> guard against unreasonable arguments or being invoked twice on the same
> network device could cause problems.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Just figured that /sbin/bridge-stp is a shell script.
Network interfaces can contain a lot of funny characters,
maybe this is after all a security issue.

Thanks,
//richard
