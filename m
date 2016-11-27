From: Jon LaBadie <jonfu@jgcomp.com>
Subject: ip manpage comments
Date: Sat, 26 Nov 2016 21:49:32 -0500
Message-ID: <20161127024932.GA9954@cyber.jgcomp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a2i805.smtp2go.com ([103.47.207.37]:57453 "EHLO
        a2i805.smtp2go.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752830AbcK0DAT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 22:00:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Though not new to *nix, I am new to using the ip(8) command.
Thus some of my historical assumptions about ip may be wrong.

It seems that an inclusive manpage for the ip command was
broken up into a shorter ip(8) manpage and 15 or more
ip-<subcommand>(8) manpages.  I'm basing this assumption
on long, inclusive manpages on https://linux.die.net/man/8/ip
and CentOS 6 while CentOS 7 and Fedora 24 each have the
sub-divided style.

I won't debate the wisdom of this subdivision, only comment
on how it was done.

The ip(8) manpage make no mention of additional subordinate
documents.  The listing of the additional documents in the
See Also section is insufficient.  This section is typically
used to mention related commands and other sources of reference
materials such as info docs, wikis, blogs, or mailing lists.

When one does investigate one of the subordinate manpages,
they do not state that they document subcommands of the
ip command.  In fact, on the ip-address(8) manpage it says

  The `ip address command' ...   (quotes added)

My first thought was "typo", this is the manpage about the
"ip-address" command.  Of course there is no ip-address command.
But "ip address" is not a command either, it is the "ip" command
with an argument.

There are several commands that have broken their manpage into
several manpages.  Two which come to mind are zsh(1) and perl(1).
The authors of those pages clearly state on the primary manpage
that this is an overview page and give clear pointers to the
additional manpages as well as additional documentation.  I would
recommend reorganizing the ip(8) manpage in a similar fashion.

Thank you for consideration of my opinion and for the development
of an awesome tool.

Jon
-- 
Jon H. LaBadie                  jonfu@jgcomp.com
