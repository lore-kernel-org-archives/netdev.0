From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 4/5] lguest: use KVM hypercalls
Date: Wed, 15 Apr 2009 07:10:32 -0700
Message-ID: <m1ocuynh2f.fsf@fess.ebiederm.org>
References: <49DDE91A.8060603@trash.net> <49DDF614.1060909@trash.net>
	<m1bpr6hqrm.fsf@fess.ebiederm.org> <49E47976.8020005@trash.net>
	<20090415083610.GA8579@gondor.apana.org.au>
	<20090415084717.GA8829@gondor.apana.org.au>
	<m18wm2rqy6.fsf@fess.ebiederm.org>
	<20090415132802.GA11408@gondor.apana.org.au>
	<m1skkaox8h.fsf@fess.ebiederm.org>
	<20090415134610.GA11683@gondor.apana.org.au>
	<20090415135502.GA11827@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, virtualization-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
	Matias Zabaljauregui <zabaljauregui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
In-Reply-To: <20090415135502.GA11827-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org> (Herbert Xu's
	message of "Wed\, 15 Apr 2009 21\:55\:02 +0800")
List-Unsubscribe: <https://ozlabs.org/mailman/options/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
List-Help: <mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=subscribe>
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org> writes:

> On Wed, Apr 15, 2009 at 09:46:10PM +0800, Herbert Xu wrote:
>>
>> Does anything actually rely on this behaviour?
>
> I doubt it :)
>
>> If not we should just change it to not do that.
>
> It appears that this was introduced in
>
> commit c70f182940f988448f3c12a209d18b1edc276e33
> Author: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Date:   Tue Jan 20 11:07:17 2009 +0000
>
>     tun: Fix races between tun_net_close and free_netdev.
>
> Presumably in order to fix the problem of trying to unregister
> the same device twice.
>
> I what we should do is to mark the device as dead instead of
> detaching if a third party deletes it.  That's all you need
> to know to stop close(2) from trying the unregister a device
> that's already been unregistered.
>
> What else am I missing?

Hopefully my earlier explanation helps.  I will get back to
you as soon as I can.  But I am off on vacation for the
rest of the week.

Eric
