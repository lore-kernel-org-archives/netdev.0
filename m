From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Tue, 8 Feb 2005 07:04:13 +0100 (CET)
Message-ID: <Pine.LNX.4.62.0502080658310.32526@kaber.coreworks.de>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        linux-audit@redhat.com
To: "Serge E. Hallyn" <serue@us.ibm.com>
In-Reply-To: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 4 Feb 2005, Serge E. Hallyn wrote:
> Most audit control messages are sent over netlink.  In order to properly
> log the identity of the sender of audit control messages, we would like
> to add the loginuid to the netlink_creds structure, as per the attached
> patch.

Reception of netlink messages in the kernel happens in the context
of the sending process, so you can simply call
audit_get_loginuid(current->audit_context) in audit_receive_msg().

Regards
Patrick
