From: Pavel Roskin <proski@gnu.org>
Subject: Re: orinoco upstream merge to kernel status?
Date: Tue, 29 Mar 2005 11:46:44 -0500
Message-ID: <1112114804.29524.8.camel@dv>
References: <1112110149.16060.13.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1112110149.16060.13.camel@dcbw.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-29 at 10:29 -0500, Dan Williams wrote:
> Hi,
> 
> I've just looked over the diff between current 2.6.12rc1 and upstream
> "for_linus" branch of the orinoco drivers.  I found that the delta is
> almost 100% due to monitor mode/scanning code that's found in the
> upstream driver.  That's the last _important_ piece that has to get
> merged to the mainline kernel.  It seems all the other trivial pieces
> have been merged already.
> 
> David/Pavel: is it correct that the only bits left are monitor
> mode/scanning, and that they cannot be separated?  Should that diff just
> be posted as a patch to netdev?  Or are there other issues with the
> "for_linus" branch right now that prevent the final merge from
> occurring?
> 
Hi, Dan!

The remaining differences are only in orinoco.c and orinoco.h.  However,
it's more than just monitor mode and scanning.  The driver in 2.6.12-rc1
is basically version 0.14alpha2, and there have been more changes since
then.  For example, support for joining a specific access point.

David submitted previous changes.  I can submit the rest if David hasn't
done it.  David?

-- 
Regards,
Pavel Roskin
