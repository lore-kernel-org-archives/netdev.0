From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: /net
Date: Wed, 12 Nov 2008 18:24:24 -0800
Message-ID: <20081112182424.77bf6c54@extreme>
References: <f188924b0811121725o2e99574as3362c9a7b9348b08@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Fred ." <eldmannen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <f188924b0811121725o2e99574as3362c9a7b9348b08-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Nov 2008 02:25:33 +0100
"Fred ." <eldmannen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Plan 9 has a /net directory.
> 
> 
> /net is the API for all TCP/IP, and it can be used even with scripts
> or shell tools, writing data to control files to write and read
> connections. Relevant sub-directories like /net/tcp and /net/udp are
> used to interface to prospective protocols. You can implement a NAT by
> mounting a /net from a perimeter machine with a public IP, while
> connecting to it from an internal network of private IP addresses,
> using the Plan 9 protocol 9P in the internal network. Or you can
> implement a VPN by mounting a /net directory from a remote gateway,
> using secured 9P over the public Internet.
> 
> Here would be an example of using union (a stack) directories in /net:
> just like inheritance in OOP, you can take one (possibly remote)
> /special directory and bind another local special directory on top of
> that, adding some new control files and hiding others. The union
> directory now is like a child object instance of the original parent.
> The functionality of the original can be partially modified. Consider
> the /net file system. If you modify or hide its /net/udp sub-directory
> you may control or extend the UDP interface with local filter
> processes, still leaving the original /net/tcp running intact, perhaps
> in a remote machine. Note that name space is per process: if you give
> an untrusted application a limited, modified /net union directory, you
> restrict its access to the net.
> 
> All this makes it easy to combine "objects" or file systems written in
> different languages on different systems, while using standard naming,
> access control and security of the file system, largely transparently
> to the programmer.
> 
> 
> I saw that Linux implemented many things from Plan 9 such as /proc,
> union mounts, etc. Will Linux also implement /net ?

Sure patches accepted for review anytime :-)
--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
