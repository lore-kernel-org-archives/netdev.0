From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: Fix off-by-one in max protocol-type check
Date: Sat, 29 May 2004 12:38:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529123829.10778ffe.davem@redhat.com>
References: <40B71A1C.5080400@trash.net>
	<40B71ABD.5060600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <40B71ABD.5060600@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 May 2004 12:55:57 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Patrick McHardy wrote:
> > This patch fixes an off-by-one in inet_register_protosw and
> > inet6_register_protosw. inetsw is an array of size SOCK_MAX,
> > the check allows access to index SOCK_MAX. Patch applies
> > to 2.4 and 2.6.
> 
> Forgot the patch, sorry ;)

Applied.
