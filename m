From: "Rob Meijer" <capibara@xs4all.nl>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal
     firewalls"
Date: Wed, 21 Jan 2009 08:25:29 +0100 (CET)
Message-ID: <57962.77.61.51.106.1232522729.squirrel@webmail.xs4all.nl>
Reply-To: rmeijer@xs4all.nl
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Samir Bellabes" <sam@synack.fr>, imipak@yahoo.com,
	"linux-security-module" <linux-security-module@vger.kernel.org>,
	"Stephan Peijnik" <stephan@peijnik.at>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: "Casey Schaufler" <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, January 21, 2009 02:18, Casey Schaufler wrote:
>
>> we don't need this at all, as we are in process context, syscall can
>> sleep.
>> Trust me, it's strange to have it's web browser freezing waiting for a
>> timeout if the userspace part doesn't reply, but if it's replying, it's
>> transparent.
>
> I hate to be the one to say this, but it looks to me as if the
> easiest way to solve the problems that you have outlined would
> be to create a new LSM based on SELinux with two important
> changes. The first would be to have a separate policy for each
> user (or process tree) and the second would be to make the policy
> specification discretionary. SELinux has all the mechanism you're
> talking about, but you want the policy being enforced to reflect
> a set of "personal firewall" rules rather than "domain type" rules.
>  From the lobby at LCA in Hobart these rule sets are pretty hard to
> tell apart. And let's not have the "SELinux isn't designed to do
> that" row. Of course it isn't. Nonetheless, the personal firewall
> sure sounds a lot like SELinux if you ignore the MAC/DAC difference.

I think this is a perfect example of where using MAC 'and' DAC or rather
centrally 'and' user managed profiles would be very fruitful. If you can
create a purely permissive centrally managed per user profile, in fact
delegating a permission set and allow each user to decompose and
discretionary delegate parts of this profile to programs run by this same
user, but with MAC restrictions when delegating to a process run by a
different user, you would IMHO have a very powerful combination of MAC and
DAC.

I'm not sure however a label based MAC system would be best suited for
combining MAC and DAC in such a way.



Rob

