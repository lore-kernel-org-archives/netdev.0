From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Xen-devel] [PATCH 0/4] [Net] Support accelerated network plugin modules
Date: Fri, 15 Jun 2007 14:11:31 +0200
Message-ID: <200706151411.31748.mb@bu3sch.de>
References: <C29835DB.931B%Keir.Fraser@cl.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kieran Mansley <kmansley@solarflare.com>,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:55217
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755630AbXFOMNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 08:13:12 -0400
In-Reply-To: <C29835DB.931B%Keir.Fraser@cl.cam.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 15 June 2007 13:26:03 Keir Fraser wrote:
> On 15/6/07 11:46, "Kieran Mansley" <kmansley@solarflare.com> wrote:
> 
> > This is a repost of some earlier patches to the xen-devel mailing list,
> > with a number of changes thanks to some useful suggestions from others.
> 
> The coding style needs fixing in various ways.
> 
> Hard tabs need to be used, no spaces inside brackets, but should include
> spaces between if/while/for and bracket, and bracket and brace:
>     if (foo) {
> Not
>     if( foo ){
>     if(foo ) {
> Or various other possibilities.
> 
> No use of the following please:
> If (foo) return 1; else return 0;
> Is clearer as:
> Return foo;

But it's not the same.
	return !!foo;
would be the same. And yes, it does matter:

int x(void)
{
	unsigned long long v = 0xFF0000000000ULL;
	/*foo*/
	return v;
}

-- 
Greetings Michael.
