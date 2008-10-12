From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [linux-cifs-client] Fwd: [PATCH] Fix CIFS compilation with
 CONFIG_KEYS unset
Date: Sun, 12 Oct 2008 16:16:34 -0400
Message-ID: <20081012161634.5e410c24@tleilax.poochiereds.net>
References: <200810121315.37203.rjw@sisk.pl>
	<524f69650810120640v41778375wf0a7662e773da26f@mail.gmail.com>
	<20081012095903.33427ee8@tleilax.poochiereds.net>
	<524f69650810120953t2ec8100cpdddc3ddfce0406d9@mail.gmail.com>
	<524f69650810120957t1a81f23lf3fd75fee78e72c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl,
	"samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
	netdev@vger.kernel.org, cooldavid@cooldavid.org,
	"linux-cifs-client@lists.samba.org" <linux-cifs-client@lists.samba.org>,
	David Miller <davem@davemloft.net>, LKML <linux-kernel@vger.kernel.org>
To: "Steve French" <smfrench@gmail.com>
Return-path: <samba-technical-bounces+gnsi-samba-technical=m.gmane.org@lists.samba.org>
In-Reply-To: <524f69650810120957t1a81f23lf3fd75fee78e72c3@mail.gmail.com>
List-Unsubscribe: <https://lists.samba.org/mailman/listinfo/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/archive/samba-technical>
List-Post: <mailto:samba-technical@lists.samba.org>
List-Help: <mailto:samba-technical-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=subscribe>
Sender: samba-technical-bounces+gnsi-samba-technical=m.gmane.org@lists.samba.org
Errors-To: samba-technical-bounces+gnsi-samba-technical=m.gmane.org@lists.samba.org
List-Id: netdev.vger.kernel.org

On Sun, 12 Oct 2008 11:57:47 -0500
"Steve French" <smfrench@gmail.com> wrote:

> On Sun, Oct 12, 2008 at 11:53 AM, Steve French <smfrench@gmail.com> wrote:
> > On Sun, Oct 12, 2008 at 8:59 AM, Jeff Layton <jlayton@redhat.com> wrote:
> >> On Sun, 12 Oct 2008 08:40:39 -0500
> >> "Steve French" <smfrench@gmail.com> wrote:
> >>
> >> Actually, I like Adrian/Rafael's fix better. I think we should avoid
> >> cluttering up the code with #ifdef's where possible. key_put() already
> >> is a no-op when CONFIG_KEYS is disabled. We might as well do the same
> >> thing with key_revoke().
> > I don't think it matters much - but we probably shouldn't be
> > overriding global functions.
> 
> To clarify, I like fixing it in keys.h better than overriding it in
> cifs, but in the meantime we need an ifdef in cifs until keys.h
> changes.
> 
> 
> 

It's your call, but if we're going to carry a temporary patch, then I'd
prefer to just carry the one that adds the empty key_revoke definition.
I don't think there's much benefit to changing the cifs code for this,
but I don't feel very strongly about it either way...
-- 
Jeff Layton <jlayton@redhat.com>
