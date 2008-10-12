From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: Fwd: [PATCH] Fix CIFS compilation with
	CONFIG_KEYS unset
Date: Sun, 12 Oct 2008 22:12:26 +0800
Message-ID: <20081012140936.M27503@cooldavid.org>
References: <200810121315.37203.rjw@sisk.pl>
	<524f69650810120640v41778375wf0a7662e773da26f@mail.gmail.com>
	<20081012095903.33427ee8@tleilax.poochiereds.net>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
Cc: rjw@sisk.pl,
	"linux-cifs-client@lists.samba.org" <linux-cifs-client@lists.samba.org>,
	netdev@vger.kernel.org,
	"samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
	David Miller <davem@davemloft.net>, LKML <linux-kernel@vger.kernel.org>
To: Jeff Layton <jlayton@redhat.com>,"Steve French" <smfrench@gmail.com>
Return-path: <linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org>
In-Reply-To: <20081012095903.33427ee8@tleilax.poochiereds.net>
List-Unsubscribe: <https://lists.samba.org/mailman/listinfo/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/archive/linux-cifs-client>
List-Post: <mailto:linux-cifs-client@lists.samba.org>
List-Help: <mailto:linux-cifs-client-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=subscribe>
Sender: linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org
Errors-To: linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org
List-Id: netdev.vger.kernel.org

On Sun, 12 Oct 2008 09:59:03 -0400, Jeff Layton wrote
> On Sun, 12 Oct 2008 08:40:39 -0500
> "Steve French" <smfrench@gmail.com> wrote:
> 
> > Rafael and Guo-Fu,
> > The following change to address the compile error that you noted is
> > slightly different than what you suggested but should fix what you
> > found.
> >
> 
> Actually, I like Adrian/Rafael's fix better. I think we should avoid
> cluttering up the code with #ifdef's where possible. key_put() already
> is a no-op when CONFIG_KEYS is disabled. We might as well do the same
> thing with key_revoke().
I found that my patch was not reasonable at all.
And I agree with Jeff.

Guo-Fu Tseng
