From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: fealnx oopses
Date: Tue, 30 Mar 2004 01:18:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403300118.55631.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <200403300050.42367.vda@port.imtp.ilyichevsk.odessa.ua> <4068AC87.2030506@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        Andreas Henriksson <andreas@fjortis.info>, netdev@oss.sgi.com,
        Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4068AC87.2030506@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 30 March 2004 01:08, Jeff Garzik wrote:
> Denis Vlasenko wrote:
> > I think bug can be considered fixed if I can start
> > netcat UDP flood, wait however long I want, then press
> > ctrl-C and get my bash prompt back. Local netcat
> > closes socket and exits, remote netcat gets its
> > icmp 'port unreachable' and exits too. Everybody's
> > happy.
> >
> > Oopses are gone but it looks like box is so much interrupt
> > flooded that userspace has no chance of processing ctrl-C.
> > What can we do? I think driver can do something useful
> > whet it detects 'too much work in interrupt'. Disabling rx
> > for several ms seems like 'quick and dirty' way.
> >
> > Francois what do you think? Can you code something up
> > for me to test?
>
> Andreas had a francois+jgarzik patch, I thought...?
>
> Looking good...

Yes, I did all these tests with this patch.
--
vda
