From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc2 7/8] S2io: NAPI fix
Date: Thu, 14 Oct 2004 11:00:27 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416E948B.5050701@pobox.com>
References: <005601c4b18b$691ac8b0$6c10100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Francois Romieu'" <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        leonid.grossman@s2io.com, raghavendra.koushik@s2io.com,
        rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@s2io.com
In-Reply-To: <005601c4b18b$691ac8b0$6c10100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Comments on patch #7:

1) Can you prove that put_lock is really necessary, and not covered by 
other methods of synchronization?  Typically the preferred model is that 
your RX process requires _no_ spinlocks, and instead you use the net 
stack API to ensure when your RX process is, and is not, running.

otherwise, no objections to this patch
