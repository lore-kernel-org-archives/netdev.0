From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: ESFQ: request for user input
Date: Sun, 24 Jun 2007 16:09:42 -0700
Message-ID: <467EF9B6.3040801@fatooh.org>
References: <467ECB0C.6020105@fatooh.org> <467EDE48.307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: lartc <lartc@mailman.ds9a.nl>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <lartc-bounces@mailman.ds9a.nl>
In-Reply-To: <467EDE48.307@trash.net>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Corey Hickey wrote:
>> Hello,
>>
>> I haven't been keeping up with sending ESFQ [ANNOUNCE] messages to this
>> list, but I've still been working on the patch. If you're curious about
>> recent changes, take a look at the home page, ChangeLog, and README:
>>
>> http://fatooh.org/esfq-2.6/
>> http://fatooh.org/esfq-2.6/current/ChangeLog
>> http://fatooh.org/esfq-2.6/current/README
>>
>> Meanwhile, I'm interested in finally getting ESFQ included in the Linux
>> kernel. Before I start sending patches and requesting maintainer review,
>> however, there's one question I want to ask current or potential users
>> of SFQ and ESFQ:
>>
>> Should ESFQ be merged into SFQ or remain as a separate qdisc?
> 
> I've CCed netdev. I think merging parts of ESFQ (dynamic depth and
> flow number) would make a lot of sense, but I'm intending to submit
> an alternative to the ESFQ hashing scheme for 2.6.23:
> 
> http://www.mail-archive.com/netdev@vger.kernel.org/msg39156.html

Nice. I wasn't aware of that. Your patch looks like it supersedes ESFQ's
hashing, so, if it gets applied, that already removes a large chunk of
the differences between SFQ and ESFQ.

If I don't hear any opposition, then I'll keep an eye out for when your
patch gets accepted (assuming it does) and then submit patch(es) porting
the rest of ESFQ's features to SFQ.

I just subscribed myself to netdev.

> I have enough trust in ESFQ's stability that I don't think we need
> a new qdisc for this and could merge it in SFQ (and the "uses only
> 1 page" justification isn't true anymore anyway), but I also
> wouldn't mind adding a new qdisc.

Thanks for the trust; I'm sure that the patches will have to undergo
some cleanup either way, considering my newbieness to kernel development.

-Corey
