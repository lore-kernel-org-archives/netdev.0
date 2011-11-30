From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Tue, 29 Nov 2011 22:18:02 -0800
Message-ID: <CAEP_g=-+F8bpkb8Qe1bPk65PQVNxz+VO7NoUrBCw6=GDUFbOFg@mail.gmail.com>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322050976.2039.125.camel@mojatatu>
	<20111128130409.GB16828@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20111128130409.GB16828-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2011 at 5:04 AM, Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org> wrote:
> On Wed, Nov 23, 2011 at 07:22:56AM -0500, jamal wrote:
>> I cant find one - you may. After staring at the code, I am also now
>> questioning if the existing bridge code couldnt have been re-used with
>> some small tweaks.
>
> I wasn't able to find any functionality that could not be easily
> done with the existing classifier/action code.
>
> Whether we want to go down this route though is open to debate
> as someone would have to actually implement this :)

Thanks for taking the time to go through the code Herbert.  I think
this conversation overall has suffered some from being a little vague
and high level so it helps a lot to have more people who have looked
at the code.

The main part that worries me about moving to a different approach is
the impedance mismatch that occurs from the fact that Open vSwitch is
modeling a switch and tc is not.  As Jamal alluded to above, it's
actually the bridge code which is more conceptually similar.  In my
experience, combining two disparate models makes things harder over
the long run, not easier.  It also tends to show up more in some of
the edges like userspace/kernel compatibility.

What I'd like to do is start a clean conversation (this one is far too
long already) about what an Open vSwitch built using these components
would look like and really go into the details and design
implications.
