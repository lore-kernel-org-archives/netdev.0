From: "James H. Cloos Jr." <cloos@jhcloos.com>
Subject: Re: tcp socket missing from /proc/net/tcp
Date: 27 Aug 2003 01:41:53 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3isojpsgu.fsf@lugabout.jhcloos.org>
References: <m3lltk17er.fsf@lugabout.jhcloos.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
Resent-Message-ID: <m3fzjnpkdd.fsf@lugabout.jhcloos.org>
To: "James H. Cloos Jr." <cloos@jhcloos.com>
In-Reply-To: <m3lltk17er.fsf@lugabout.jhcloos.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A further update:

The socket does not need to be open when sit1 is taked down; I've a
rsync now that is showing the same symptom, but was started well
after a 'ifconfig sit1 down'.

After an ssh occured and closed, the rsync started showing up.

Perhaps there is an off-by-one error?

-JimC
